public with sharing class IPS_CreateHouseholdAccount {


    private static final Boolean ENFORCE_MEMBER_ID_MATCH = true;

    /**
     * @param List<String>IdList Id list of Plan Members to create Contact and Account
     * @description Creates Contact and Account for Plan Members and pushes it to dependents. If there is a matching contact in the system,
     * updates the contact information according to plan member data.
     */
    @future
    public static void CreateHouseholdAccountAndPortalUserPlanMember(Set < Id > IdList) {
        //List Of Patients To Select
        System.debug('= List of patients = ' + IdList);
        List < IntPS__Patient__c > AllNewPatients = [SELECT Id, Name, RecordTypeId, IntPS__Address_Full__c, IntPS__Address__c, IntPS__Age__c, IntPS__Alternate_Phone_Number__c,
            IntPS__City__c, IntPS__Country__c, IntPS__DateOfBirth__c, IntPS__Date_Of_Birth__c, IntPS__Department_Agency_Number__c,
            IntPS__Effective_Date__c, IntPS__Employer__c, IntPS__Employment_Begin_Date__c, IntPS__Employment_Status_Code__c,
            IntPS__ExternalID__c, IntPS__First_Name__c, IntPS__Gender__c, IntPS__Last_Name__c, IntPS__Medicare_Plan_Code__c,
            IntPS__Member_Id__c, IntPS__Middle_Name__c, IntPS__Family_Id__c, IntPS__Patient_Unique_ID__c, IntPS__Phone_Number__c, IntPS__Plan_Member__c, IntPS__Plan_Provider__c, IntPS__Plan_Type__c, IntPS__Relationship_Code__c, IntPS__SSN__c, IntPS__Social_Security_Number__c, IntPS__State__c, IntPS__Street1__c, IntPS__Street__c, IntPS__Zip_Code__c, IntPS__Email__c, Account__c, Portal_User__c, (SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, IntPS__Address_Full__c, IntPS__Address__c, IntPS__Age__c, IntPS__Age_formula__c, IntPS__Alternate_Phone_Number__c, IntPS__City__c, IntPS__Country__c, IntPS__DateOfBirth__c, IntPS__Date_Of_Birth__c,
                IntPS__Department_Agency_Number__c, IntPS__Effective_Date__c, IntPS__Employer__c, IntPS__Employment_Begin_Date__c, IntPS__Employment_Status_Code__c, IntPS__ExternalID__c, IntPS__First_Name__c, IntPS__Gender__c, IntPS__Last_Name__c, IntPS__Medicare_Plan_Code__c, IntPS__Member_Id__c, IntPS__Middle_Name__c, IntPS__Family_Id__c, IntPS__Patient_Unique_ID__c, IntPS__Phone_Number__c, IntPS__Plan_Member__c, IntPS__Plan_Provider__c, IntPS__Plan_Type__c, IntPS__Relationship_Code__c, IntPS__SSN__c, IntPS__Social_Security_Number__c, IntPS__State__c, IntPS__Street1__c, IntPS__Street__c, IntPS__Zip_Code__c, IntPS__Email__c, Account__c, Portal_User__c FROM IntPS__Patients__r) FROM IntPS__Patient__c Where
            RecordType.name = 'Plan Member'
            AND ID =: IdList // 'a2Z8F0000008RFWUA2'
        ];

        Map < String, Account > PatAccMap = new Map < String, Account > (); // To keep Relation between Patient and created Plan Member Accounts
        Map < String, Contact > PatContactMap = new Map < String, Contact > ();
        Map < String, IntPS__Patient__c > emailToPatient = new Map < String, IntPS__Patient__c > ();
        for (IntPS__Patient__c onePM: AllNewPatients) {
            emailToPatient.put(onePM.IntPS__Email__c, onePM);
        }
        List < Account > accountUpdateList = new List < Account > ();
        List < Contact > contactUpdateList = new List < Contact > ();
        List < Account > accountList = [SELECT Id, Email__c, RecordType.Name FROM Account WHERE Email__c IN: emailToPatient.keySet()];
        List < Contact > contactList = [SELECT Id, Email,Member_ID__c,Birthdate, AccountId FROM Contact WHERE Email IN: emailToPatient.keySet()];
        Map < String, Account > accountMap = new Map < String, Account > ();
        Map < String, Contact > contactMap = new Map < String, Contact > ();
        for (Account acc: accountList) {
            accountMap.put(acc.Email__c, acc);
        }
        for (Contact con: contactList) {
            String key = '';
            if(String.isNotBlank(con.Email)) {
                key += con.Email;
            }
            if(ENFORCE_MEMBER_ID_MATCH) {
                key += String.isNotBlank(con.Member_ID__c)?con.Member_ID__c:'';
                key += String.valueOf(con.Birthdate);
            }

            if(String.isNotBlank(con.Email)) {
                if(ENFORCE_MEMBER_ID_MATCH && String.isNotBlank(con.Member_ID__c) && con.Birthdate != null) {
                    contactMap.put(key, con);
                }else {
                    contactMap.put(key, con);
                }
            }
        }

        Id householdTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        for (IntPS__Patient__c onePM: AllNewPatients) {
            if (onePM.Account__c == null) {
                if (!accountMap.containsKey(onePM.IntPS__Email__c)) {
                    Account A_PM = new Account(
                        RecordTypeId = householdTypeId,
                        Name = String.isNotBlank(onePM.INTPS__First_Name__c) ? onePM.INTPS__First_Name__c + ' ' + onePM.INTPS__Last_Name__c : '',
                        Email__c = String.isNotBlank(onePM.IntPS__Email__c) ? onePM.IntPS__Email__c : '',
                        BillingStreet = String.isNotBlank(onePM.IntPS__Street__c) ? onePM.IntPS__Street__c : '',
                        BillingCity = String.isNotBlank(onePM.IntPS__City__c) ? onePM.IntPS__City__c : '',
                        BillingState = String.isNotBlank(onePM.IntPS__State__c) ? onePM.IntPS__State__c : '',
                        BillingPostalCode = String.isNotBlank(onePM.IntPS__Zip_Code__c) ? onePM.IntPS__Zip_Code__c : '',
                        Phone = String.isNotBlank(onePM.IntPS__Phone_Number__c) ? onePM.IntPS__Phone_Number__c : '',
                        Created_By_Patient_Trigger__c = true
                    );
                    if (onePM.IntPS__Street1__c != null && onePM.IntPS__Street1__c != '') {
                        A_PM.BillingStreet += ' ' + onePM.IntPS__Street1__c;
                    }
                    //accountList.add(A_PM);
                    PatAccMap.Put(onePM.IntPS__Email__c, A_PM);
                }
            }

            if (onePM.Portal_User__c == null) {
                String key = '';
                key+= String.isNotBlank(onePM.IntPS__Email__c)?onePM.IntPS__Email__c:'';
                if(ENFORCE_MEMBER_ID_MATCH) {
                    key+= String.isNotBlank(onePM.IntPS__Family_Id__c)?onePM.IntPS__Family_Id__c:'';
                    key+= String.valueOf(onePM.IntPS__Date_Of_Birth__c); 
                }
                if (!contactMap.containsKey(key)) {
                    Account tempA = new Account(Email__c = onePM.IntPS__Email__c);
                    Contact C_PM = new Contact(
                        FirstName = String.isNotBlank(onePM.INTPS__First_Name__c) ? onePM.INTPS__First_Name__c : '',
                        LastName = String.isNotBlank(onePM.INTPS__Last_Name__c) ? onePM.INTPS__Last_Name__c : '',
                        Email = String.isNotBlank(onePM.IntPS__Email__c) ? onePM.IntPS__Email__c : '',
                        Account = tempA,
                        MailingStreet = String.isNotBlank(onePM.IntPS__Street__c) ? onePM.IntPS__Street__c : '',
                        MailingCity = String.isNotBlank(onePM.IntPS__City__c) ? onePM.IntPS__City__c : '',
                        MailingState = String.isNotBlank(onePM.IntPS__State__c) ? onePM.IntPS__State__c : '',
                        MailingPostalCode = String.isNotBlank(onePM.IntPS__Zip_Code__c) ? onePM.IntPS__Zip_Code__c : '',
                        Birthdate = onePM.IntPS__Date_Of_Birth__c,
                        Member_ID__c = String.isNotBlank(onePM.IntPS__Family_Id__c) ? onePM.IntPS__Family_Id__c : '',
                        Created_By_Patient_Trigger__c = true
                    );
                    if (onePM.IntPS__Street1__c != null && onePM.IntPS__Street1__c != '') {
                        C_PM.MailingStreet += ' ' + onePM.IntPS__Street1__c;
                    }
                    //contactList.add(C_PM);
                    PatContactMap.Put(key, C_PM);
                }
            }
        }

        System.debug('BEFORE UPDATE ACC ---');
        System.debug(JSON.serializePretty(PatAccMap));
        System.debug('BEFORE UPDATE CONTACT ---');
        System.debug(JSON.serializePretty(PatContactMap));
        //Insert accounts and contacts
        if (!PatAccMap.isEmpty()) {
            database.Insert(PatAccMap.values());
        }

        if (!PatContactMap.isEmpty()) {
            database.Insert(PatContactMap.values());
        }

        Datetime dtNow = System.now();
        //Patient sharing
        List < IntPS__Patient__c > updatePat = new List < IntPS__Patient__c > ();
        for (IntPS__Patient__c onePM: AllNewPatients) {
            IntPS__Patient__c pat = new IntPS__Patient__c();
            pat.id = onePM.id;
            pat.Household_Error__c = '';
            pat.Account__c = onePM.Account__c;
            String key = '';
            key+= onePM.IntPS__Email__c;
            if(ENFORCE_MEMBER_ID_MATCH) {
                key+= onePM.IntPS__Family_Id__c ;
                key+= String.valueOf(onePM.IntPS__Date_Of_Birth__c);
            }
            if (onePM.Account__c == null) {
                if (PatAccMap.containsKey(onePM.IntPS__Email__c)) {
                    pat.Account__c = PatAccMap.get(onePM.IntPS__Email__c).Id;
                } else if (accountMap.containsKey(onePM.IntPS__Email__c)) {
                    pat.Account__c = accountMap.get(onePM.IntPS__Email__c).Id;
                }
            }
            if (onePM.Portal_User__c == null) {
                if (PatContactMap.containsKey(key)) {
                    pat.Portal_User__c = PatContactMap.get(key).Id;
                } else if (contactMap.containsKey(key)) {
                    pat.Portal_User__c = contactMap.get(key).Id;
                    Contact updatedContact = contactMap.get(key);
                    updatedContact.Birthdate = onePM.IntPS__Date_Of_Birth__c;
                    updatedContact.Member_ID__c = String.isNotBlank(onePM.IntPS__Family_Id__c) ? onePM.IntPS__Family_Id__c : '';
                    updatedContact.AccountId = pat.Account__c;
                    updatedContact.Patient_Match_Status__c = 'Successful';
                    updatedContact.Portal_Matched_Email_Sent_Date__c = dtNow;
                    contactUpdateList.add(updatedContact);
                }
            }
            updatePat.add(pat);

            for (IntPS__Patient__c oneDep: onePM.IntPS__Patients__r) {
                IntPS__Patient__c dep = new IntPS__Patient__c();
                dep.id = oneDep.id;
                dep.Account__c = pat.Account__c;
                dep.Portal_User__c = pat.Portal_User__c;
                updatePat.add(dep);
            }
        }

        if (!updatePat.isEmpty()) {
            database.update(updatePat); // Update Patients with Person Account
        }
        if (!contactUpdateList.isEmpty()) {
            BatchMergePortalContact bmp = new BatchMergePortalContact();
            bmp.sendEmail('Portal_Match_Success', contactUpdateList);
            bmp.assignPermissionSet(contactUpdateList);
            update contactUpdateList;
        }

    }

    /**
     * @param Set<Id>IdList Id list of dependents to create portal contact
     * @description Creates a portal contact for the dependents if it cant find a matched contact in the system. It doesn't create 
     *  an account since the account stucture represents household information. To be able to update contact's account information, dependent must have an account.
     */
    @future
    public static void CreatePortalUserDependents(Set < Id > IdList) {
        // Id householdTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        List < IntPS__Patient__c > dependentPatients = [
            SELECT
            Id,
            Name,
            RecordTypeId,
            IntPS__Address_Full__c,
            IntPS__Address__c,
            IntPS__Age__c,
            IntPS__Alternate_Phone_Number__c,
            IntPS__City__c,
            IntPS__Country__c,
            IntPS__DateOfBirth__c,
            IntPS__Date_Of_Birth__c,
            IntPS__Department_Agency_Number__c,
            IntPS__Effective_Date__c,
            IntPS__Employer__c,
            IntPS__Employment_Begin_Date__c,
            IntPS__Employment_Status_Code__c,
            IntPS__ExternalID__c,
            IntPS__First_Name__c,
            IntPS__Gender__c,
            IntPS__Last_Name__c,
            IntPS__Medicare_Plan_Code__c,
            IntPS__Member_Id__c,
            IntPS__Middle_Name__c,
            IntPS__Family_Id__c,
            IntPS__Old_Id__c,
            IntPS__Patient_Unique_ID__c,
            IntPS__Phone_Number__c,
            IntPS__Plan_Member__c,
            IntPS__Plan_Provider__c,
            IntPS__Plan_Type__c,
            IntPS__Relationship_Code__c,
            IntPS__SSN__c,
            IntPS__Social_Security_Number__c,
            IntPS__State__c,
            IntPS__Street1__c,
            IntPS__Street__c,
            IntPS__Superscription__c,
            IntPS__Zip_Code__c,
            IntPS__Email__c,
            Account__c,
            Account__r.Email__c,
            Portal_User__c,
            Portal_User__r.Email
            FROM IntPS__Patient__c
            WHERE RecordType.name = 'Dependent'
            AND ID =: IdList // 'a2Z8F0000008RFWUA2'
        ];

        Set < string > emailList = new Set < string > ();
        for (IntPS__Patient__c onePM: dependentPatients) {
            if (onePM.IntPS__Email__c != null) {
                emailList.add(onePM.IntPS__Email__c);
            }
        }
        MAp < string, Account > accountMap = new Map < string, Account > ();
        MAp < string, Contact > contactMap = new Map < string, Contact > ();
        System.debug('emailList-------' + emailList);
        if (!emailList.isEmpty()) {
            List < Account > acclist = [SELECT Id, Email__c FROM Account WHERE Email__c IN: emailList];
            List < Contact > contactList = [SELECT Id, Email,Member_ID__c,Birthdate FROM Contact WHERE Email IN: emailList];
            for (Account acc: acclist) {
                accountMap.put(acc.Email__c, acc);
            }
            for (Contact contact: contactList) {
                String key = '';
                if(String.isNotBlank(contact.Email)) {
                    key+= contact.Email;
                }

                if(ENFORCE_MEMBER_ID_MATCH) {
                    key += String.isNotBlank(contact.Member_ID__c)?contact.Member_ID__c:'';
                    key += String.valueOf(contact.Birthdate);
                }
                if(String.isNotBlank(contact.Email)) {
                    if(ENFORCE_MEMBER_ID_MATCH && String.isNotBlank(contact.MEMBER_ID__c) && contact.Birthdate != null) {
                        contactMap.put(key, contact);
                    } else {
                        contactMap.put(key, contact);
                    }
                }
            }
        }

        List < Account > PersonAccountList = new List < Account > (); // All Person Accounts
        Map < String, Account > PatAccMap = new Map < String, Account > ();
        Map < String, Contact > PatConMap = new Map < String, Contact > ();
        List < String > accIDSet = new List < String > ();
        for (IntPS__Patient__c onePM: dependentPatients) {
            String key = '';
            key+= String.isNotBlank(onePM.IntPS__Email__c) ? onePM.IntPS__Email__c : '';
            if(ENFORCE_MEMBER_ID_MATCH && String.isNotBlank(onePM.IntPS__Family_Id__c) && onePM.IntPS__Date_Of_Birth__c != null) {
                key+=onePM.IntPS__Family_Id__c;
                key+=String.valueOf(onePM.IntPS__Date_Of_Birth__c);
            }

            if (!contactMap.containsKey(key)) {
                // Account tempA = new Account(Email__c = onePM.IntPS__Email__c);
                Contact C_PM = new Contact(
                    FirstName = String.isNotBlank(onePM.INTPS__First_Name__c) ? onePM.INTPS__First_Name__c : '',
                    LastName = String.isNotBlank(onePM.INTPS__Last_Name__c) ? onePM.INTPS__Last_Name__c : '',
                    Email = String.isNotBlank(onePM.IntPS__Email__c) ? onePM.IntPS__Email__c : '',
                    // Account = tempA,
                    MailingStreet = String.isNotBlank(onePM.IntPS__Street__c) ? onePM.IntPS__Street__c : '',
                    MailingCity = String.isNotBlank(onePM.IntPS__City__c) ? onePM.IntPS__City__c : '',
                    MailingState = String.isNotBlank(onePM.IntPS__State__c) ? onePM.IntPS__State__c : '',
                    MailingPostalCode = String.isNotBlank(onePM.IntPS__Zip_Code__c) ? onePM.IntPS__Zip_Code__c : '',
                    Birthdate = onePM.IntPS__Date_Of_Birth__c,
                    Member_ID__c = String.isNotBlank(onePM.IntPS__Family_Id__c) ? onePM.IntPS__Family_Id__c : '',
                    Created_By_Patient_Trigger__c = true,
                    AccountId = onePM.Account__c
                );
                if (onePM.IntPS__Street1__c != null && onePM.IntPS__Street1__c != '') {
                    C_PM.MailingStreet += ' ' + onePM.IntPS__Street1__c;
                }
                //contactList.add(C_PM);
                PatConMap.Put(key, C_PM);
            }

        }
        // if (!PatAccMap.isEmpty()) {
        //     // Database.Insert(PatAccMap.values());
        // }
        if (!PatConMap.isEmpty()) {
            Database.insert(PatConMap.values());
        }

        Datetime dtNow = System.now();
        List < IntPS__Patient__c > updatePat = new List < IntPS__Patient__c > ();
        List < Contact > contactUpdateList = new List < Contact > ();
        for (IntPS__Patient__c onePM: dependentPatients) {
            IntPS__Patient__c pat = new IntPS__Patient__c();
            pat.id = onePM.id;
            pat.Household_Error__c = '';
            pat.Account__c = onePM.Account__c;
            
            String key = '';
            key+= String.isNotBlank(onePM.IntPS__Email__c) ? onePM.IntPS__Email__c : '';
            if(ENFORCE_MEMBER_ID_MATCH && String.isNotBlank(onePM.IntPS__Family_Id__c) && onePM.IntPS__Date_Of_Birth__c != null) {
                key+=onePM.IntPS__Family_Id__c;
                key+=String.valueOf(onePM.IntPS__Date_Of_Birth__c);
            }
            if (onePM.Portal_User__c == null || onePM.Portal_User__r.Email != onePM.IntPS__Email__c) {
                if (PatConMap.containsKey(key)) {
                    pat.Portal_User__c = PatConMap.get(key).Id;
                } else if (contactMap.containsKey(key)) {
                    pat.Portal_User__c = contactMap.get(key).Id;
                    Contact updatedContact = contactMap.get(key);
                    updatedContact.Birthdate = onePM.IntPS__Date_Of_Birth__c;
                    updatedContact.Member_ID__c = String.isNotBlank(onePM.IntPS__Family_Id__c) ? onePM.IntPS__Family_Id__c : '';
                    updatedContact.AccountId = onePM.Account__c;
                    updatedContact.Patient_Match_Status__c = 'Successful';
                    updatedContact.Portal_Matched_Email_Sent_Date__c = dtNow;
                    contactUpdateList.add(updatedContact);
                }
            }
            updatePat.add(pat);
        }

        if (!updatePat.isEmpty()) {
            database.update(updatePat); // Update Patients with Person Account
        }
        if (!contactUpdateList.isEmpty()) {
            BatchMergePortalContact bmp = new BatchMergePortalContact();
            bmp.sendEmail('Portal_Match_Success', contactUpdateList);
            bmp.assignPermissionSet(contactUpdateList);
            update contactUpdateList;
        }

    }
}