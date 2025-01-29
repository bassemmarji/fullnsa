public with sharing class PatientTriggerHandler {



    /**
     * 
     * @param triggerNew Triggered patients
     * @description Checks the Plan Member and if it has an account or contact, updates the patient's account and contact as plan member's
     */
    public static void updateContactAccountLookup(List<IntPS__Patient__c> triggerNew) {
        Id dependentId = Schema.SObjectType.IntPS__Patient__c.getRecordTypeInfosByName().get('Dependent').getRecordTypeId();
        Set<Id> planMemberIds = new Set<Id>();
        for (IntPS__Patient__c patient : triggerNew) {
            if(patient.IntPS__Plan_Member__c!=null && patient.RecordTypeId == dependentId) {
                planMemberIds.add(patient.IntPS__Plan_Member__c);
            }
        }
        if(planMemberIds.isEmpty()) {
            return;
        }

        Map<Id, IntPS__Patient__c> planMembers = new Map<Id, IntPS__Patient__c>([SELECT Id,Account__c,Portal_User__c FROM IntPS__Patient__c WHERE Id IN:planMemberIds AND (Account__c != NULL OR Portal_User__c != NULL)]);
        if(planMembers.isEmpty()) {
            return;
        }
        for (IntPS__Patient__c patient : triggerNew) {
            if(planMembers.containsKey(patient.IntPS__Plan_Member__c)) {
                IntPS__Patient__c planMember = planMembers.get(patient.IntPS__Plan_Member__c);
                if(planMember.Account__c != null) {
                    patient.Account__c = planMembers.get(patient.IntPS__Plan_Member__c).Account__c;
                }
                if(planMember.Portal_User__c != null) {
                    patient.Portal_User__c = planMembers.get(patient.IntPS__Plan_Member__c).Portal_User__c;
                }
            }
        }
        
    }

    /**
     * 
     * @param triggerNew List of triggered patients
     * @param oldMap Old versions of triggered patients
     */
    public static void createUserHelper(List<IntPS__Patient__c> triggerNew,Map<Id,IntPS__Patient__c> oldMap) {
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> createAccountContact = new Set<Id>();
        Set<Id> createContactDependent = new Set<Id>();
        List<IntPS__Patient__c> createAll = new List<IntPS__Patient__c>();
        for (IntPS__Patient__c patient : triggerNew) {
            
            if(patient.Create_User_CS__c && oldMap.get(patient.Id).Create_User_CS__c == false) {
                if(String.isNotBlank(patient.IntPS__Email__c) && String.isNotBlank(patient.IntPS__Not_Unique_Member_Id__c) && patient.Portal_User__c != null) {
                    contactIdSet.add(patient.Portal_User__c);
                }else {
                    patient.addError('Email address and Patient Contact is required to create a user!');
                }
            } else if(patient.Create_User__c && oldMap.get(patient.Id).Create_User__c == false) {
                System.debug(JSON.serializePretty(patient));
                if(String.isNotBlank(patient.IntPS__Email__c) && String.isNotBlank(patient.IntPS__Not_Unique_Member_Id__c)) {
                    createAll.add(patient);
                }else {
                    patient.addError('Email address and Member Id is required to create a user!');
                }
            } else if(patient.Create_Account_Plan_Member__c && patient.Create_Account_Plan_Member__c != oldMap.get(patient.id).Create_Account_Plan_Member__c && patient.Account__c == null && patient.Record_Type_Name__c == 'Plan Member') {
                if(String.isNotBlank(patient.IntPS__Not_Unique_Member_Id__c)) {
                    createAccountContact.add(patient.id);
                }else {
                    patient.addError('Member Id is required to create an Account and Contact!');
                }
            } else if(patient.Create_Portal_Contact_Dependent__c && patient.Create_Portal_Contact_Dependent__c != oldMap.get(patient.id).Create_Portal_Contact_Dependent__c && patient.Record_Type_Name__c == 'Dependent') {
                if(String.isNotBlank(patient.IntPS__Not_Unique_Member_Id__c) && patient.Account__c != null) {
                    createContactDependent.add(patient.id);
                }else {
                    patient.addError('Member Id and Account is required to create a contact. Please create Account and Contact for Plan Member first!');
                }
            }
        }

        if(!contactIdSet.isEmpty()) {
            List<Contact> contacts = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE Id IN :contactIdSet AND Id NOT IN (SELECT ContactId FROM User)];
            if(!contacts.isEmpty()) {
                CreateNSAPortalUser.insertUsers(contacts,null);
            }
        }
        if(!createAccountContact.isEmpty()) {
            IPS_CreateHouseholdAccount.CreateHouseholdAccountAndPortalUserPlanMember(createAccountContact);
        }
        if(!createContactDependent.isEmpty()) {
            System.debug(createContactDependent);
            IPS_CreateHouseholdAccount.CreatePortalUserDependents(createContactDependent);
        }
        if(!createAll.isEmpty()) {
            CreateNSAPortalUser.createUser(createAll);
        }
    }
    
        
}