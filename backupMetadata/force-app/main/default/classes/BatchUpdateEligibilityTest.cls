@IsTest
public class BatchUpdateEligibilityTest {
    @TestSetup
    static void setup() {
        Account account = new Account();
        account.Name = 'Test Account';
        account.IntPS__External_ID__c = 'Test Submitter';
        insert account;
        IntPS__Health_Plan__c hp = new IntPS__Health_Plan__c();
        hp.Name = 'SILVER 70 HMO 1000/55* + CHILD DENTAL ALT';
        hp.IntPS__Deductible_Calculation_Type__c = 'Embedded';
        hp.IntPS__Out_Of_Pocket_Calculation_Type__c = 'Embedded';
        hp.IntPS__Out_of_Pocket_Max_Family__c = 15100;
        hp.IntPS__Out_of_Pocket_Max_Individual__c = 7500;
        hp.IntPS__Plan_Deductible_Family__c = 2000;
        hp.IntPS__Plan_Deductible_Individual__c = 1000;
        //hp.Plan_Deductible_Individual__c = 950;
        insert hp;
        List<IntPS__Patient__c> patients = new List<IntPS__Patient__c>();
        for (Integer i = 0; i < 100; i++) {
            IntPS__Patient__c patient = new IntPS__Patient__c();
            patient.IntPS__First_Name__c = 'John '+i;
            patient.IntPS__Last_Name__c = 'Doe '+i;
            patients.add(patient);
        }
        insert patients;
        List<IntPS__Eligibility__c> eligibilities = new List<IntPS__Eligibility__c>();
        for (IntPS__Patient__c patient : patients) {
            IntPS__Eligibility__c testElig = new IntPS__Eligibility__c();
            testElig.IntPS__Payer_Name__c = account.Id;
            testElig.IntPS__Health_Plan__c=hp.id;
            testElig.IntPS__Patient__c = patient.Id;
            eligibilities.add(testElig);
            // eligibilities.add(testElig);
        }
        insert eligibilities;
        List<IntPS__Eligibility__c> eligibilities2 = new List<IntPS__Eligibility__c>();
        for (IntPS__Eligibility__c elg : eligibilities) {
            elg.Id = null;
            eligibilities2.add(elg);
        }
        insert eligibilities2;
    }

    @IsTest
    static void testBatch(){
        
        Test.startTest();
        Id jobIdVariable = Database.executeBatch(new BatchUpdateEligibility(), 200);
        Test.stopTest();
        
    }
}