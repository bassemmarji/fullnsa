/**
 * 
 * @author Mert Cenk Kilic <mkilic@integratedpayorsolutions.com>
 * Updated By Bassem Marji / 21-02-2024
 * @since 2022-12-21
 */
public with sharing class ScheduleMatchPortalMember implements Schedulable {

    private final Boolean ENFORCE_MEMBER_ID_MATCH = true;

    public void execute(SchedulableContext sc) {
        matchPatients();
    }

    public void matchPatients() {
        // Boolean useContact = false;
        List < User > users = [
            SELECT 
            Id,
            Username, 
            Email, 
            Member_ID__c, 
            Date_Of_Birth__c, 
            ContactId, 
            Contact.Email,
            Contact.Member_ID__c,
            Contact.Birthdate,
            Contact.Portal_Not_Matched_Email_Sent_Date__c,
            Contact.Portal_Matched_Email_Sent_Date__c FROM User WHERE IsActive = true AND Confirmed_User_Info__c = true AND
            Contact.Account.Name = 'Self Register' AND (Contact.Portal_Not_Matched_Email_Sent_Date__c = NULL OR Contact.Portal_Matched_Email_Sent_Date__c = NULL)
        ];
        if(users.isEmpty()) {
            return;
        }
        
        System.debug('= Users To Match List Size = ' + users.size());
        
        Set < String > emailSet = new Set < String > ();
        Set < String > memberIdSet = new Set < String > ();
        Map < String, User > keyToUser = new Map < String, User > ();
        for (User user: users) {
            
            String key = '';
            String email = '';
            String memberId = '';
            String dateOfBirth = '';

            if(String.isNotBlank(user.Contact.Member_ID__c) && user.Contact.Birthdate != null){
                // useContact = true;
                email = user.Contact.Email;
                memberId = user.Contact.Member_ID__c;
                dateOfBirth = String.valueOf(user.Contact.Birthdate);
            }else {
                email = user.Email;
                if(String.isNotBlank(user.Member_ID__c)){
                    memberId = user.Member_ID__c;
                }
                if(user.Date_Of_Birth__c != null) {
                    dateOfBirth = String.valueOf(user.Date_Of_Birth__c);
                }
            }
            
            emailSet.add(email);
            key+= email;
            if(ENFORCE_MEMBER_ID_MATCH) {
                key+= memberId;
                key+= dateOfBirth;
                memberIdSet.add(memberId);
            }


            keyToUser.put(key, user);
        }
		
        System.debug('=emailSet='+emailSet);
        System.debug('=memberIdSet='+memberIdSet);
        
        //Updated By Bassem On 02-21-2024
        //String query = 'SELECT ';
        //query += ' Id,AccountId,Email,Birthdate,Member_ID__c,Created_By_Patient_Trigger__c '; 
        //query += ' FROM Contact ';
        //query += ' WHERE ';
        //query +=    ' Id IN (SELECT Portal_User__c FROM IntPS__Patient__c WHERE Portal_User__c!=null) '; 
        //query += '       Contact.Account.Name != \'Self Register\' ';
        //query += '   AND Email IN ( \'' + String.join(new List<String>(emailSet), ',') + '\')';
        //if(ENFORCE_MEMBER_ID_MATCH) {
        //    query+=' AND Member_ID__c IN ( \'' + String.join(new List<String>(memberIdSet),',') + '\')';
        //}

        String query = 'SELECT ';
        query += ' Id,AccountId,Email,Birthdate, ' +
                   'Member_ID__c,Created_By_Patient_Trigger__c FROM Contact ' +
            'WHERE Id IN (SELECT Portal_User__c FROM IntPS__Patient__c WHERE Portal_User__c!=null) ' +
            ' AND Contact.Account.Name != \'Self Register\' ';
        query+='AND Email IN :emailSet ';
        if(ENFORCE_MEMBER_ID_MATCH) {
            query+='AND Member_ID__c IN :memberIdSet ';
        }
        
		System.debug('=query='+query);

        Map < Id, Contact > contacts = new Map < Id, Contact > ((List < Contact > ) Database.query(query));
        System.debug('=contacts Map Size=' + contacts.size());
        
        System.debug('============ USER MAP ==================');
        System.debug(JSON.serializePretty(keyToUser));
        System.debug('===== CONTACTS ===========');
        System.debug(contacts);
        // if(contacts.isEmpty()) {
        //     return;
        // }
        List < Contact > contactsToDelete = new List < Contact > ();
        List < Contact > updatedContacts = new List < Contact > ();
        List<IntPS__Patient__c> updatedPatients = new List<IntPS__Patient__c>();
        Map<Contact, Set<Id>> masterToDuplicate = new Map<Contact, Set<Id>>();
        for (Contact contact: contacts.values()) {
            String key = '';
            key += contact.Email;
            if(ENFORCE_MEMBER_ID_MATCH) {
                key += contact.Member_ID__c;
                key += String.valueOf(contact.Birthdate);
            }
            if (keyToUser.containsKey(key)) {
                User user = keyToUser.get(key);
                Boolean useContact = false;
                if(String.isNotBlank(user.Contact.Member_ID__c) && user.Contact.Birthdate != null) {
                    useContact = true;
                }
                Contact updatedContact = new Contact(
                    Id = user.ContactId,
                    AccountId = contact.AccountId,
                    Email = useContact? user.Contact.Email: user.Email,
                    Member_ID__c = useContact? user.Contact.Member_ID__c :user.Member_ID__c,
                    Birthdate = useContact?user.Contact.Birthdate :user.Date_Of_Birth__c
                );
                updatedContacts.add(updatedContact);
                Set<Id> duplicateIds = new Set<Id>();
                if(masterToDuplicate.containsKey(updatedContact)) {
                    duplicateIds = masterToDuplicate.get(updatedContact);
                }
                duplicateIds.add(contact.Id);
                masterToDuplicate.put(updatedContact, duplicateIds);
                keyToUser.remove(key);
            }
        }

        Datetime dateTimeNow = System.now();
        List<Contact> notMatchedContacts = new List<Contact>();
        for (User user : keyToUser.values()) {
            Contact nmContact = new Contact(
                Id = user.ContactId,
                Email = user.Contact.Email,
                Member_ID__c = user.Member_ID__c,
                Birthdate = user.Date_Of_Birth__c,
                Portal_Not_Matched_Email_Sent_Date__c = dateTimeNow,
                Patient_Match_Status__c = 'Failed'
            );
            if(user.Contact.Portal_Not_Matched_Email_Sent_Date__c == null) {
                notMatchedContacts.add(nmContact);
            }
        }
        
		System.debug('= notMatchedContacts List Size = ' + notMatchedContacts.size());
        
        if(!notMatchedContacts.isEmpty()) {
            System.debug('============ NOT MATCHED CONTACTS ==============');
            System.debug(JSON.serializePretty(notMatchedContacts));
            update notMatchedContacts;
        }
        
		System.debug('= updatedContacts List Size = ' + updatedContacts.size());

        if(!updatedContacts.isEmpty()) {
            System.debug('---------UPDATED Contacts --------------');
            System.debug(updatedContacts);

            System.debug('============ MERGE MAP ==========');
            System.debug(masterToDuplicate);
            Id jobIdVariable = Database.executeBatch(new BatchMergePortalContact(masterToDuplicate), 5);
        }

        if(!notMatchedContacts.isEmpty()) {
            BatchMergePortalContact batchMerge = new BatchMergePortalContact();
            batchMerge.sendEmail('Portal_Match_Failed',notMatchedContacts);
        }


    }
}