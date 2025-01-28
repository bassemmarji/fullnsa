@IsTest
public class CustomProcessingLogTriggerTest {
    // @TestSetup
    // static void setup() {
    // }

    @IsTest
    static void triggerTest() {

        Account payer = new Account(
            Name = 'Test Payer'
        );

        insert payer;
        IntPS__Processing_Log__c pl = new IntPS__Processing_Log__c();
        insert pl;

        Id planMemberId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();
        Id dependentId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();
        IntPS__Health_Plan__c hp = new IntPS__Health_Plan__c(
            Name = 'Test Plan',
            Plan_Type__c = 'Medical',
            IntPS_NSA__RbP__c = false,
            IntPS__Deductible_Calculation_Type__c = 'Embedded',
            IntPS__Out_Of_Pocket_Calculation_Type__c = 'Embedded',
            IntPS__Work_Plan__c = '9 AM to 7 PM on Monday to Friday',
            IntPS__ExternalID__c = 'test',
            IntPS__Term_Date__c = Date.valueOf('2099-01-01')
        );
        insert hp;

        Long CURRENT_TIME = Datetime.now().getTime();
        List < IntPS__Patient__c > planMembers = new List < IntPS__Patient__c > ();
        List < IntPS__Patient__c > dependents = new List < IntPS__Patient__c > ();
        List < IntPS__Eligibility__c > eligibilities = new List < IntPS__Eligibility__c > ();
        List < Contact > userContacts = new List < Contact > ();
        List < Contact > patientContacts = new List < Contact > ();
        List < User > users = new List < User > ();
        List < String > uniqueStrings = new List < String > {
            'mkilic+10@ankamee.com',
            'mkilic+20@ankamee.com',
            'mkilic+30@ankamee.com',
            'mkilic+40@ankamee.com',
            'mkilic+50@ankamee.com',
            'mkilic+60@ankamee.com',
            'mkilic+70@ankamee.com',
            'mkilic+80@ankamee.com',
            'mkilic+90@ankamee.com',
            'mkilic+00@ankamee.com'
        };
        List < String > uniqueNames = new List < String > {
            'Isaac',
            'Kian',
            'Anas',
            'Mathilda',
            'Mina',
            'Elouise',
            'Humaira',
            'Liberty',
            'Traci',
            'Kane'
        };
        List < String > uniqueLastNames = new List < String > {
            'Allison',
            'Case',
            'Hanna',
            'Shepherd',
            'Holland',
            'Tyler',
            'Castaneda',
            'Levine',
            'Stephens',
            'Cohen'
        };
        Date todaysDate = System.today();
        Date termDate = Date.valueOf('2099-01-01');
        // IntPS__Health_Plan__c hp = [SELECT Id FROM IntPS__Health_Plan__c LIMIT 1];
        // Account payer = [SELECT Id FROM Account LIMIT 1];
        for (Integer count = 0; count < 10; count++) {
            IntPS__Patient__c patient = new IntPS__Patient__c();
            patient.IntPS__First_Name__c = uniqueNames[count];
            patient.IntPS__Last_Name__c = uniqueLastNames[count];
            patient.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(count);
            patient.IntPS__ExternalID__c = 'External' + String.valueOf(count);
            patient.IntPS__Email__c = uniqueStrings[count];
            patient.IntPS__Date_Of_Birth__c = Date.valueOf('1990-12-12');
            patient.RecordTypeId = planMemberId;
            planMembers.add(patient);
            IntPS__Patient__c tempPatient = new IntPS__Patient__c();
            tempPatient.IntPS__ExternalID__c = 'External' + String.valueOf(count);
			IntPS__Patient__c dependent = new IntPS__Patient__c();
            dependent.IntPS__First_Name__c = 'Dependent ' + String.valueOf(count);
            dependent.IntPS__Last_Name__c = uniqueLastNames[count];
            dependent.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(count);
            dependent.IntPS__ExternalID__c = 'DepExternal' + String.valueOf(count);
            dependent.IntPS__Plan_Member__r = tempPatient;
            dependent.RecordTypeId = dependentId;
            dependents.add(dependent);
            IntPS__Patient__c tempDep = new IntPS__Patient__c();
            tempDep.IntPS__ExternalID__c = 'DepExternal' + String.valueOf(count);

            eligibilities.add(
                new IntPS__Eligibility__c(
                    Name = 'Plan Member Test Eligibility',
                    IntPS__Patient__r = tempPatient,
                    IntPS__Health_Plan__c = hp.Id,
                    IntPS__Term_Date__c = termDate,
                    IntPS__Begin_Date__c = todaysDate,
                    IntPS__Payer_Name__c = payer.Id,
                    IntPS__Processing_Log__c = pl.Id
                )
            );
            eligibilities.add(
                new IntPS__Eligibility__c(
                    Name = 'Plan Member Test Eligibility',
                    IntPS__Patient__r = tempDep,
                    IntPS__Health_Plan__c = hp.Id,
                    IntPS__Term_Date__c = termDate,
                    IntPS__Begin_Date__c = todaysDate,
                    IntPS__Payer_Name__c = payer.Id,
                    IntPS__Processing_Log__c = pl.Id
                )
            );

        }
        Database.insert(planMembers);
        Database.insert(dependents);
        Database.insert(eligibilities);
        IntPS__Processing_Log__c pl1 = [SELECT Id FROM IntPS__Processing_Log__c LIMIT 1];
        pl1.Create_Patients_Contact__c = true;
        update pl1;
    }

    @IsTest
    static void errorTest(){
        Id planMemberId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Plan Member').getRecordTypeId();
        Id dependentId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();

        Date todaysDate = System.today();
        Date termDate = Date.valueOf('2099-01-01');
        Account payer = new Account(
            Name = 'Test Payer'
        );
        insert payer;
        IntPS__Health_Plan__c hp = new IntPS__Health_Plan__c(
            Name = 'Test Plan',
            Plan_Type__c = 'Medical',
            IntPS_NSA__RbP__c = false,
            IntPS__Deductible_Calculation_Type__c = 'Embedded',
            IntPS__Out_Of_Pocket_Calculation_Type__c = 'Embedded',
            IntPS__Work_Plan__c = '9 AM to 7 PM on Monday to Friday',
            IntPS__ExternalID__c = 'test',
            IntPS__Term_Date__c = Date.valueOf('2099-01-01')
        );
        insert hp;
        IntPS__Processing_Log__c pl2 = new IntPS__Processing_Log__c();
        insert pl2;
        IntPS__Patient__c patient = new IntPS__Patient__c();
        patient.IntPS__First_Name__c = 'PM First';
        patient.IntPS__Last_Name__c = 'PM Last';
        patient.IntPS__Not_Unique_Member_Id__c = '111111111111111';
        patient.IntPS__ExternalID__c = 'External' + String.valueOf(110);
        patient.IntPS__Email__c = 'test@test.com';
        patient.IntPS__Date_Of_Birth__c = Date.valueOf('1990-12-12');
        patient.RecordTypeId = planMemberId;
        // planMembers.add(patient);
        insert patient;
        IntPS__Patient__c patient2 = new IntPS__Patient__c();
        patient2.IntPS__First_Name__c = 'PM2 First';
        patient2.IntPS__Last_Name__c = 'PM2 Last';
        patient2.IntPS__Not_Unique_Member_Id__c = '111111111111111';
        patient2.IntPS__ExternalID__c = 'External2' + String.valueOf(110);
        patient2.IntPS__Email__c = 'test@test.com';
        patient2.IntPS__Date_Of_Birth__c = Date.valueOf('1990-12-12');
        patient2.RecordTypeId = planMemberId;
        // planMembers.add(patient);
        insert patient2;
        // IntPS__Patient__c tempPatient = new IntPS__Patient__c();
        // tempPatient.IntPS__ExternalID__c = 'External' + String.valueOf(0);
        IntPS__Patient__c dependent = new IntPS__Patient__c();
        dependent.IntPS__First_Name__c = 'Dependent ' + String.valueOf(0);
        dependent.IntPS__Last_Name__c = 'PM Last';
        // dependent.IntPS__Not_Unique_Member_Id__c = String.valueOf(CURRENT_TIME) + String.valueOf(0);
        // dependent.IntPS__ExternalID__c = 'DepExternal' + String.valueOf(0);
        dependent.IntPS__Plan_Member__c = patient.Id;
        dependent.RecordTypeId = dependentId;
        // dependents.add(dependent);
        insert dependent;
        // IntPS__Patient__c tempDep = new IntPS__Patient__c();
        // tempDep.IntPS__ExternalID__c = 'DepExternal' + String.valueOf(110);

        IntPS__Eligibility__c pmElg = 
            new IntPS__Eligibility__c(
                Name = 'Plan Member Test Eligibility',
                IntPS__Patient__c = patient.Id,
                IntPS__Health_Plan__c = hp.Id,
                IntPS__Term_Date__c = termDate,
                IntPS__Begin_Date__c = todaysDate,
                IntPS__Payer_Name__c = payer.Id,
                IntPS__Processing_Log__c = pl2.Id
            );
        IntPS__Eligibility__c pmElg2 = 
        new IntPS__Eligibility__c(
            Name = 'Plan Member2 Test Eligibility',
            IntPS__Patient__c = patient2.Id,
            IntPS__Health_Plan__c = hp.Id,
            IntPS__Term_Date__c = termDate,
            IntPS__Begin_Date__c = todaysDate,
            IntPS__Payer_Name__c = payer.Id,
            IntPS__Processing_Log__c = pl2.Id
        );
        IntPS__Eligibility__c dpElg =
            new IntPS__Eligibility__c(
                Name = 'Plan Member Test Eligibility',
                IntPS__Patient__c = dependent.Id,
                IntPS__Health_Plan__c = hp.Id,
                IntPS__Term_Date__c = termDate,
                IntPS__Begin_Date__c = todaysDate,
                IntPS__Payer_Name__c = payer.Id,
                IntPS__Processing_Log__c = pl2.Id
            );
        insert pmElg;
        insert pmElg2;
        insert dpElg;
        Test.startTest();
        pl2.Create_Patients_Contact__c = true;
        update pl2;
        Test.stopTest();
        
    }
}