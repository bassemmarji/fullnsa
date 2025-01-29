/**
 * 
 * @author Mert Cenk Kilic <mkilic@integratedpayorsolutions.com>
 * @since 3/13/2023
 */
public with sharing class CreateNSAPortalUser {

    /**
     * 
     * @param patients takes triggered patients list
     */
    public static void createUser(List<IntPS__Patient__c> patients) {
        Map<Id, IntPS__Patient__c> patientsMap = new Map<Id, IntPS__Patient__c>();
        Set<String> emailSet = new Set<String>();
        Set<String> memberIdSet = new Set<String>();
        for (IntPS__Patient__c patient : patients) {
            patientsMap.put(patient.Id,patient);
            emailSet.add(patient.IntPS__Email__c);
            memberIdSet.add(patient.IntPS__Not_Unique_Member_Id__c);
        }
        List<IntPS__Patient__c> dependents = [SELECT Id,
                                                     Name,
                                                     IntPS__First_Name__c,
                                                     IntPS__Last_Name__c,
                                                     IntPS__Email__c,
                                                     IntPS__Street__c,
                                                     IntPS__City__c,
                                                     IntPS__State__c,
                                                     IntPS__Zip_Code__c,
                                                     IntPS__Date_Of_Birth__c,
                                                     IntPS__Not_Unique_Member_Id__c,
                                                     IntPS__Phone_Number__c,IntPS__Plan_Member__c,Account__c,Portal_User__c FROM IntPS__Patient__c 
                                                     WHERE IntPS__Plan_Member__c IN:patients AND Id NOT IN:patients];
        List<Account> storedAccounts = [SELECT Id,Name,Email__c,Member_ID__c FROM Account WHERE Member_ID__c IN:memberIdSet];
        List<Contact> storedContacts = [SELECT Id,
                                               FirstName,
                                               LastName,
                                               Email,
                                               AccountId,
                                               Member_ID__c,
                                               Birthdate,(SELECT Id FROM Users) FROM Contact WHERE Member_ID__c IN: memberIdSet];
        Map<String, Account> memberIdToAccount = new Map<String, Account>();
        Map<String, Contact> keyToContact = new Map<String, Contact>();
        for (Account acc : storedAccounts) {
            memberIdToAccount.put(acc.Member_ID__c, acc);
        }
        for (Contact con : storedContacts) {
            String firstName = String.isNotBlank(con.FirstName)?con.FirstName.toLowerCase():'';
            String lastName = String.isNotBlank(con.LastName)?con.LastName.toLowerCase():'';
            String key = firstName+lastName+con.Member_ID__c+String.valueOf(con.Birthdate);
            if(!con.Users.isEmpty()) { // make sure that contact has a user
                keyToContact.put(key, con);
            }
        }
        Map<Id, Account> patientToAccount = createAccount(patientsMap,memberIdToAccount);
        Map<Id, Contact> patientToContact = createContact(patientsMap,patientToAccount,memberIdToAccount,keyToContact);


        List<Contact> contactsToCreateUser = new List<Contact>();
        Map<String, String> contactIdToPatientId = new Map<String, String>();
        for (IntPS__Patient__c pat : patients) {
            String key = pat.IntPS__First_Name__c.toLowerCase()+pat.IntPS__Last_Name__c.toLowerCase()+pat.IntPS__Not_Unique_Member_Id__c+String.valueOf(pat.IntPS__Date_Of_Birth__c);
            System.debug('=-=-=-=-=-=-=key=-=-=-=-=-=-=-=');
            System.debug(JSON.SerializePretty(key));
            System.debug('=-=-=-=-=-=-=keyToContact=-=-=-=-=-=-=-=');
            System.debug(JSON.serializePretty(keyToContact));
            System.debug('=-=-=-=-=-=-=patientToContact=-=-=-=-=-=-=-=');
            System.debug(JSON.SerializePretty(patientToContact));
            if(keyToContact.containsKey(key) && (pat.Portal_User__c == null || pat.Record_Type_Name__c == 'Dependent')) {
                pat.Portal_User__c = keyToContact.get(key).Id;
                // contactsToCreateUser.add(keyToContact.get(key)); //
            }else if(patientToContact.containsKey(pat.Id) && (pat.Portal_User__c == null || pat.Record_Type_Name__c == 'Dependent')) {
                pat.Portal_User__c = patientToContact.get(pat.Id).Id;
                if(String.isNotBlank(pat.IntPS__Email__c)){
                    contactsToCreateUser.add(patientToContact.get(pat.Id));
                    contactIdToPatientId.put(patientToContact.get(pat.Id).Id, pat.Id);
                }
            }else if(keyToContact.containsKey(key) && String.isNotBlank(pat.IntPS__Email__c) && pat.Portal_User__c != null){
                contactsToCreateUser.add(keyToContact.get(key));
                contactIdToPatientId.put(keyToContact.get(key).Id, pat.Id);
            }


            if(memberIdToAccount.containsKey(pat.IntPS__Not_Unique_Member_Id__c) && pat.Account__c == null) {
                pat.Account__c = memberIdToAccount.get(pat.IntPS__Not_Unique_Member_Id__c).Id;
            }else if(patientToAccount.containsKey(pat.Id) && pat.Account__c == null) {
                pat.Account__c = patientToAccount.get(pat.Id).Id;
            }
            patientsMap.put(pat.Id,pat);
        }
        List<IntPS__Patient__c> updatedDependents = new List<IntPS__Patient__c>();
        for (IntPS__Patient__c dep : dependents) {
            if(patientsMap.containsKey(dep.IntPS__Plan_Member__c)) {
                if(dep.Account__c == null || dep.Portal_User__c == null) {
                    dep.Account__c = patientsMap.get(dep.IntPS__Plan_Member__c).Account__c;
                    dep.Portal_User__c = patientsMap.get(dep.IntPS__Plan_Member__c).Portal_User__c;
                    updatedDependents.add(dep);
                }
            }
        }
        if(!updatedDependents.isEmpty()) {
            update updatedDependents;
        }
        
        if(!contactsToCreateUser.isEmpty()) {
            insertUsers(contactsToCreateUser,contactIdToPatientId);
        }
    }

    /**
     * 
     * @param patientsMap triggered patients map
     * @param patientToAccount new created accounts
     * @param memberIdToAccount accounts in the system
     * @param keyToContact contacts in the system
     * @return  `Map<Id, Contact>` Returns created contacts by mapping to patients
     */
    public static Map<Id, Contact> createContact(Map<Id, IntPS__Patient__c> patientsMap, Map<Id, Account> patientToAccount,Map<String, Account> memberIdToAccount,Map<String, Contact> keyToContact) {
        Map<Id, Contact> patientToContact = new Map<Id, Contact>();
        System.debug('PATIENTS MAP==================');
        System.debug(JSON.serializePretty(patientsMap));
        for (IntPS__Patient__c pat : patientsMap.values()) {
            String firstName = String.isNotBlank(pat.INTPS__First_Name__c)?pat.INTPS__First_Name__c.toLowerCase():'';
            String lastName = String.isNotBlank(pat.INTPS__Last_Name__c)?pat.INTPS__Last_Name__c.toLowerCase():'';
            String key = firstName+lastName+pat.IntPS__Not_Unique_Member_Id__c+String.valueOf(pat.IntPS__Date_Of_Birth__c);
            if (!keyToContact.containsKey(key) && (pat.Record_Type_Name__c == 'Dependent' || pat.Portal_User__c == null)) {
                String accId = pat.Account__c;
                if(patientToAccount.containsKey(pat.Id)) {
                    accId = patientToAccount.get(pat.Id).Id;
                }else if(memberIdToAccount.containsKey(pat.IntPS__Not_Unique_Member_Id__c)) {
                    accId = memberIdToAccount.get(pat.IntPS__Not_Unique_Member_Id__c).Id;
                }

                if(String.isNotBlank(accId)) {
                    Contact portalContact = new Contact(
                        FirstName = String.isNotBlank(pat.INTPS__First_Name__c) ? pat.INTPS__First_Name__c : '',
                        LastName = String.isNotBlank(pat.INTPS__Last_Name__c) ? pat.INTPS__Last_Name__c : '',
                        Email = String.isNotBlank(pat.IntPS__Email__c) ? pat.IntPS__Email__c : '',
                        AccountId = accId,
                        MailingStreet = String.isNotBlank(pat.IntPS__Street__c) ? pat.IntPS__Street__c : '',
                        MailingCity = String.isNotBlank(pat.IntPS__City__c) ? pat.IntPS__City__c : '',
                        MailingState = String.isNotBlank(pat.IntPS__State__c) ? pat.IntPS__State__c : '',
                        MailingPostalCode = String.isNotBlank(pat.IntPS__Zip_Code__c) ? pat.IntPS__Zip_Code__c : '',
                        Birthdate = pat.IntPS__Date_Of_Birth__c,
                        Member_ID__c = String.isNotBlank(pat.IntPS__Not_Unique_Member_Id__c) ? pat.IntPS__Not_Unique_Member_Id__c : '',
                        Patient_Match_Status__c = 'Successful'
                    );
                    patientToContact.put(pat.Id, portalContact);
                }
            }

        }
        if(!patientToContact.isEmpty()) {
            insert patientToContact.values();
        }
        return patientToContact;
    }

    /**
     * 
     * @param patientsMap triggered patients map
     * @param memberIdToAccount accounts in the system
     * @return  `Map<Id, Account>` returns an account map for patients
     */
    public static Map<Id, Account> createAccount(Map<Id, IntPS__Patient__c> patientsMap,Map<String, Account> memberIdToAccount) {
        Id householdTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Map<Id, Account> patientToAccount = new Map<Id, Account>();
        for (IntPS__Patient__c patient : patientsMap.values()) {
            if (patient.Account__c == null && !memberIdToAccount.containsKey(patient.IntPS__Not_Unique_Member_Id__c)) {
                Account account = new Account(
                    RecordTypeId = householdTypeId,
                    Name = String.isNotBlank(patient.INTPS__First_Name__c) ? patient.INTPS__First_Name__c + ' ' + patient.INTPS__Last_Name__c : '',
                    Email__c = String.isNotBlank(patient.IntPS__Email__c) ? patient.IntPS__Email__c : '',
                    BillingStreet = String.isNotBlank(patient.IntPS__Street__c) ? patient.IntPS__Street__c : '',
                    BillingCity = String.isNotBlank(patient.IntPS__City__c) ? patient.IntPS__City__c : '',
                    BillingState = String.isNotBlank(patient.IntPS__State__c) ? patient.IntPS__State__c : '',
                    BillingPostalCode = String.isNotBlank(patient.IntPS__Zip_Code__c) ? patient.IntPS__Zip_Code__c : '',
                    Phone = String.isNotBlank(patient.IntPS__Phone_Number__c) ? patient.IntPS__Phone_Number__c : '',
                    Member_ID__c = String.isNotBlank(patient.IntPS__Not_Unique_Member_Id__c) ? patient.IntPS__Not_Unique_Member_Id__c : ''
                );
                patientToAccount.put(patient.Id, account);
            }
        }
        if(!patientToAccount.isEmpty()) {
            insert patientToAccount.values();
        }
        return patientToAccount;
    }

    /**
     * This method creates a user for each contact in the parameter and sends a welcome email and assigns permission set.
     * @param contacts contacts that need users to be created
     */
    public static void insertUsers(List<Contact> contacts, Map<String,String> contactToPatient) {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS NSA Portal'
            LIMIT 1
        ];

        Map<String,User> users = new Map<String,User>();
        String locale = UserInfo.getLocale();
        String timeZoneId = UserInfo.getTimezone().getID();
        System.debug('INSERT CONTACTS----------');
        System.debug(JSON.serializePretty(contacts));
        for (Contact contact : contacts) {
            
            User u = new User();
            u.ProfileId = profileId.Id;
            u.Email = contact.Email;
            u.CommunityNickname = u.Email;
            if(String.isNotBlank(u.Email)) {
                if(u.Email.length() >= 40) {
                    String splittedEmail = u.Email.substring(0, 40);
                    u.CommunityNickname = splittedEmail;
                }
                String alias = u.Email.split('@')[0];
                if(alias.length()>8) {
                    alias = alias.substring(0,8);
                }
                u.Alias = alias;
            }
            u.Username = contact.Email;
            u.FirstName = contact.FirstName;
            u.LastName = contact.LastName;
            u.ContactId = contact.Id;
            u.languagelocalekey = locale;
            u.localesidkey = locale;
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = timeZoneId;
            u.Confirmed_User_Info__c = true;
            users.put(contact.Id,u);
        }
        System.debug('=-=-=- USER -=-=-=');
        System.debug(JSON.serializePretty(users));
        if(!users.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(users.values(), false);
            List<String> failIds = new List<String>();
            Map<String, String> failMap = new Map<String, String>();
            List<IntPS__Patient__c> failedPatients = new List<IntPS__Patient__c>();
            List<Task> tasks = new List<Task>();
            Datetime dtnow = System.now();
            // String baseURL = System.Url.getSalesforceBaseUrl().toExternalForm();
            Integer i = 0;
            for (String contactId : users.keySet()) {
                if(!results[i].success && contactToPatient!=null) {
                    failMap.put(contactToPatient.get(contactId), String.valueOf(results[i].errors[0]));
                    IntPS__Patient__c patient = new IntPS__Patient__c();
                    patient.Id = contactToPatient.get(contactId);
                    patient.Failed_User_Create_Attempt__c = dtnow;
                    failedPatients.add(patient);
                }
            }
            if(!failedPatients.isEmpty()) {
                updateFailedPatients(JSON.serialize(failedPatients));
            }
            if(!failMap.isEmpty()) {
                IntPS_NSA__NSA_Error_Log__c nsaError = new IntPS_NSA__NSA_Error_Log__c();
                nsaError.IntPS_NSA__Status__c = 'Failed';
                String errorMsg = 'Count: '+String.valueOf(failMap.size())+'\n'+'Affected Patient Ids: Attached to task.';
                nsaError.IntPS_NSA__Error_Message__c = errorMsg;
                insert nsaError;
                IntPS_NSA__NSA_Error_Log__c nsa = [SELECT Name FROM IntPS_NSA__NSA_Error_Log__c WHERE Id=: nsaError.Id];
                Task task = new Task();
                task.WhatId = nsaError.Id;
                task.Status = 'Not Started';
                task.Subject = 'Other';
                task.Type = 'Other';
                insert task;
                createCSV(new List<String>{'Patient Id','Patient Url','Error Message'}, failMap, nsa.Name, task.Id);
            }
            BatchMergePortalContact bmp = new BatchMergePortalContact();
            // bmp.sendEmail('Portal_Match_Success', contacts);
            bmp.assignPermissionSet(contacts);
        }
    }

    /**
    @description create a file - generic
    */
    public static void createFile(String versionData, String title, String errorId) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        cv.FirstPublishLocationId = errorId;
        insert cv;
    }

    
/**
    @description create a CSV file from a list of Strings each string should be a row
    */
    public static void createCSV(List<String> csvHeaders, Map<String,String> csvRowList, String title, String errorId){
        String headerRow = String.join(csvHeaders,',') + '\n';
        String baseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        String concantenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        //assuming the rowList is in the correct format and each object in the list is a new record
        for(String row :csvRowList.keySet()){
           
            i++;
            concantenatedStr += (String)row+','+baseUrl+'/'+(String)row+','+(String)csvRowList.get(row) + ((i != rowListSize) ? '\n' : '');//add new line
        }
        title += '.csv';
        createFile(concantenatedStr, title,errorId);
    }

    @future
    public static void updateFailedPatients(String patients) {
        List<IntPS__Patient__c> fPatients = (List<IntPS__Patient__c>) JSON.deserialize(patients, List<IntPS__Patient__c>.class);
        update fPatients;
    }

}