@isTest
public class HealthPlanGeneratorTest {
    @IsTest public static void testHealthPlanGenerator(){
        IntPS__Health_Plan__c hp = new IntPS__Health_Plan__c();
        hp.Name = 'Test HP';
        hp.IntPS__Deductible_Calculation_Type__c = 'Embedded';
        hp.IntPS__Out_Of_Pocket_Calculation_Type__c = 'Embedded';
        insert hp;
        
        IntPS__Health_Plan_Content__c hpc = new IntPS__Health_Plan_Content__c();
        hpc.Name = 'Test HPC';
        hpc.IntPS__Health_Plan__c = hp.Id;
        insert hpc;

        IntPS__Health_Plan_Content__c hpcClone = new IntPS__Health_Plan_Content__c();
        hpcClone.Name = 'Test HPC Clone';
        hpcClone.IntPS__Health_Plan__c = hp.Id;
        insert hpcClone;
        
        IntPS__Health_Plan_Content__c hpcNew = new IntPS__Health_Plan_Content__c();
        hpcNew.Name = 'Test HPC Clone';
        hpcNew.IntPS__Health_Plan__c = hp.Id;
        insert hpcNew;

        IntPS__Health_Plan_Item__c hpi = new IntPS__Health_Plan_Item__c();
        hpi.Name = 'Test HP';
        hpi.IntPS__Health_Plan__c = hp.id;
        hpi.IntPS__Health_Plan_Content__c = hpc.id;
        insert hpi;
        
        IntPS__Health_Plan_Item__c hpi1 = new IntPS__Health_Plan_Item__c();
        hpi1.Name = 'Test HP 1';
        hpi1.IntPS__Health_Plan__c = hp.id;
        hpi1.IntPS__Health_Plan_Content__c = hpc.id;
        insert hpi1;

        IntPS__Health_Plan_Item__c hpi2 = new IntPS__Health_Plan_Item__c();
        hpi2.Name = 'Test HP 1';
        hpi2.IntPS__Health_Plan__c = hp.id;
        hpi2.IntPS__Health_Plan_Content__c = hpcClone.id;
        insert hpi2;

        IntPS__Health_Plan_Item__c hpi3 = new IntPS__Health_Plan_Item__c();
        hpi3.Name = 'Test HP 1';
        hpi3.IntPS__Health_Plan__c = hp.id;
        hpi3.IntPS__Health_Plan_Content__c = hpcClone.id;
        insert hpi3;

        IntPS__Criteria__c criteria = new IntPS__Criteria__c();
        criteria.IntPS__Condition__c = '==';
        criteria.IntPS__Description__c = 'Description';
        criteria.IntPS__Entity_Type__c = 'IntPS__Entity_Type__c';
        criteria.IntPS__Field__c = 'Name';
        criteria.IntPS__Index__c = 1000;
        //insert criteria;

        IntPS__Matching_Rule__c mr = new IntPS__Matching_Rule__c();
        mr.IntPS__Health_Plan_Item__c = hpi.Id;
        //insert mr;
        
        Test.startTest();
        System.assertNotEquals(null, HealthPlanGenerator.getHpi(hpc.Id));
        System.assertNotEquals(null, HealthPlanGenerator.getHpiStructure(hpc.Id));
        System.assertNotEquals(null, HealthPlanGenerator.getSingleHPC(hpc.Id));
        System.assertNotEquals(null, HealthPlanGenerator.getHpContent(hp.Id));
        System.assertNotEquals(null, HealthPlanGenerator.getCloneHpiStructure(hpi3.Id));
        System.assertNotEquals(null, HealthPlanGenerator.deepCloneStructureMethod(hp.Id));
        System.assertNotEquals(null, HealthPlanGenerator.deepCloneInsertHPItemsMethod(hpcClone.Id, hpcNew.Id, hpi2.Id));
        //HealthPlanGenerator.createMatchingRule('1 || 2', hpi2.Id);
        HealthPlanGenerator.getAllMatchingRule(hpi.Id);
        System.assertNotEquals(null, HealthPlanGenerator.getAllCriterias());
        Test.stopTest();
    }
}