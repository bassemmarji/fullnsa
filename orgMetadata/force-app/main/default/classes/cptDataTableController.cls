public with sharing class cptDataTableController {
    public cptDataTableController() {

    }

    @AuraEnabled (cacheable=true)
    public static List<IntPS__Procedure_Code__c> retrieveCPTs(){
        return [SELECT Id, Name, IntPS__Description__c
                FROM IntPS__Procedure_Code__c
                LIMIT 20];
    }
}