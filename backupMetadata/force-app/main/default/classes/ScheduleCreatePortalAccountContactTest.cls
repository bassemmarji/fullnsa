@isTest
public class ScheduleCreatePortalAccountContactTest {

    @isTest
    public static void testBatchProcess() {
        Id planMemberId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();
        Id dependentId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();
        Long CURRENT_TIME = Datetime.now().getTime();
        List < IntPS__Patient__c > planMembers = new List < IntPS__Patient__c > ();
        List < IntPS__Patient__c > dependents = new List < IntPS__Patient__c > ();
        List<String> uniqueStrings = new List<String>();
        List<String> uniqueNames = new List<String>();
        List<String> uniqueLastNames = new List<String>();
        for (Integer i = 0; i < 100; i++) {
            uniqueStrings.add('mkilic+'+String.valueOf(i)+'@ankamee.com');
            uniqueNames.add('FirstName'+String.valueOf(CURRENT_TIME)+String.valueOf(i));
            uniqueLastNames.add('LastName'+String.valueOf(CURRENT_TIME)+String.valueOf(i));
        }
        for (Integer count = 0; count < 100; count++) {
            IntPS__Patient__c patient = new IntPS__Patient__c();
            patient.IntPS__First_Name__c = uniqueNames[count];
            patient.IntPS__Last_Name__c = uniqueLastNames[count];
            patient.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(count);
            patient.IntPS__Email__c = uniqueStrings[count];
            patient.IntPS__Date_Of_Birth__c = Date.valueOf('1990-12-12');
            patient.RecordTypeId = planMemberId;
            patient.IntPS__ExternalID__c = String.valueOf(count);
            planMembers.add(patient);
            IntPS__Patient__c pm = new IntPS__Patient__c();
            pm.IntPS__ExternalID__c = String.valueOf(count);
            IntPS__Patient__c dependent = new IntPS__Patient__c();
            dependent.IntPS__First_Name__c = 'Dependent ' + String.valueOf(count);
            dependent.IntPS__Last_Name__c = uniqueLastNames[count];
            dependent.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(count);
            dependent.IntPS__Plan_Member__r = pm;
            dependent.RecordTypeId = dependentId;
            dependents.add(dependent);

        }
        Database.insert(planMembers);
        Database.insert(dependents);
        Test.startTest();
        System.schedule('Schedule Test', '0 55 * * * ?', new ScheduleCreatePortalAccountContact());
        Test.stopTest();

    }
}